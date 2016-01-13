defmodule Cog.Queries.Permission do
  use Cog.Queries

  def from_full_name(full_name) do
    {namespace, name} = Permission.split_name(full_name)

    from p in Cog.Models.Permission,
    join: n in assoc(p, :namespace),
    where: p.name == ^name and
           n.name == ^namespace,
    select: p
  end

  def from_bundle_name(bundle_name) do
    from p in Cog.Models.Permission,
    join: n in assoc(p, :namespace),
    # recall namespace names are the same as bundle names
    where: n.name == ^bundle_name,
    select: p
  end

  def from_group_roles(rolename) do
    from gr in Cog.Models.GroupRole,
    join: r in assoc(gr, :role),
    where: r.name == ^rolename,
    select: gr,
    preload: [:group]
  end

  def from_user_roles(rolename) do
    from ur in Cog.Models.UserRole,
    join: r in assoc(ur, :role),
    where: r.name == ^rolename,
    select: ur,
    preload: [:user]
  end
end